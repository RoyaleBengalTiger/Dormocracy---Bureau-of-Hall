import { useState } from "react";

import { violationsApi } from "@/api/violations";
import { CreateViolationPayload, ViolationPenaltyMode } from "@/types";
import { Button } from "@/components/ui/button";
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogFooter,
    DialogHeader,
    DialogTitle,
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from "@/components/ui/select";
import { toast } from "@/hooks/use-toast";

type Roommate = { id: string; username: string };

type Props = {
    open: boolean;
    onOpenChange: (open: boolean) => void;
    roommates: Roommate[];
    onSuccess: () => void;
};

export function CreateViolationModal({
    open,
    onOpenChange,
    roommates,
    onSuccess,
}: Props) {
    const [offenderId, setOffenderId] = useState("");
    const [title, setTitle] = useState("");
    const [description, setDescription] = useState("");
    const [points, setPoints] = useState<number>(0);
    const [creditFine, setCreditFine] = useState<number>(0);
    const [penaltyMode, setPenaltyMode] = useState<string>("");
    const [expiresAt, setExpiresAt] = useState("");
    const [isSubmitting, setIsSubmitting] = useState(false);

    const resetForm = () => {
        setOffenderId("");
        setTitle("");
        setDescription("");
        setPoints(0);
        setCreditFine(0);
        setPenaltyMode("");
        setExpiresAt("");
    };

    const handleSubmit = async () => {
        if (!offenderId) {
            toast({ title: "Select offender", description: "Choose a roommate." });
            return;
        }
        if (!title.trim()) {
            toast({ title: "Title required", description: "Enter a violation title." });
            return;
        }
        if (points < 0) {
            toast({ title: "Invalid points", description: "Points must be >= 0." });
            return;
        }

        const payload: CreateViolationPayload = {
            offenderId,
            title: title.trim(),
            points,
            ...(description.trim() ? { description: description.trim() } : {}),
            ...(expiresAt ? { expiresAt: new Date(expiresAt).toISOString() } : {}),
            ...(creditFine > 0 ? { creditFine } : {}),
            ...(penaltyMode ? { penaltyMode: penaltyMode as ViolationPenaltyMode } : {}),
        };

        try {
            setIsSubmitting(true);
            await violationsApi.create(payload);
            const modeLabel = penaltyMode === 'EITHER_CHOICE' ? 'Offender will choose penalty.' : 'Penalties applied.';
            toast({ title: "Violation created", description: `"${title}" recorded. ${modeLabel}` });
            resetForm();
            onSuccess();
            onOpenChange(false);
        } catch (e) {
            const msg = e instanceof Error ? e.message : "Failed to create violation";
            toast({ title: "Error", description: msg });
        } finally {
            setIsSubmitting(false);
        }
    };

    return (
        <Dialog open={open} onOpenChange={onOpenChange}>
            <DialogContent>
                <DialogHeader>
                    <DialogTitle>Create Violation</DialogTitle>
                    <DialogDescription>
                        Record a violation against a roommate.
                    </DialogDescription>
                </DialogHeader>

                <div className="space-y-4">
                    <div className="grid gap-2">
                        <Label htmlFor="offender-select">Offender</Label>
                        <Select value={offenderId} onValueChange={setOffenderId}>
                            <SelectTrigger id="offender-select">
                                <SelectValue placeholder="Choose a roommate" />
                            </SelectTrigger>
                            <SelectContent>
                                {roommates.map((u) => (
                                    <SelectItem key={u.id} value={u.id}>
                                        {u.username}
                                    </SelectItem>
                                ))}
                            </SelectContent>
                        </Select>
                    </div>

                    <div className="grid gap-2">
                        <Label htmlFor="violation-title">Title</Label>
                        <Input
                            id="violation-title"
                            placeholder="e.g. Noise after 11pm"
                            value={title}
                            onChange={(e) => setTitle(e.target.value)}
                        />
                    </div>

                    <div className="grid gap-2">
                        <Label htmlFor="violation-desc">Description (optional)</Label>
                        <Textarea
                            id="violation-desc"
                            placeholder="Additional details..."
                            value={description}
                            onChange={(e) => setDescription(e.target.value)}
                            rows={3}
                        />
                    </div>

                    <div className="grid gap-2">
                        <Label htmlFor="violation-points">Social Score Points</Label>
                        <Input
                            id="violation-points"
                            type="number"
                            min={0}
                            value={points}
                            onChange={(e) => setPoints(Math.max(0, Number(e.target.value)))}
                        />
                    </div>

                    <div className="grid gap-2">
                        <Label htmlFor="violation-creditfine">Credit Fine (optional)</Label>
                        <Input
                            id="violation-creditfine"
                            type="number"
                            min={0}
                            value={creditFine}
                            onChange={(e) => setCreditFine(Math.max(0, Number(e.target.value)))}
                        />
                        <p className="text-xs text-muted-foreground">
                            Credit amount to deduct. Goes to department treasury.
                        </p>
                    </div>

                    <div className="grid gap-2">
                        <Label htmlFor="penalty-mode">Penalty Mode</Label>
                        <Select value={penaltyMode} onValueChange={setPenaltyMode}>
                            <SelectTrigger id="penalty-mode">
                                <SelectValue placeholder="Default (social score only)" />
                            </SelectTrigger>
                            <SelectContent>
                                <SelectItem value="BOTH_MANDATORY">
                                    Both Mandatory (points + credits immediately)
                                </SelectItem>
                                <SelectItem value="EITHER_CHOICE">
                                    Offender Choice (pick one penalty)
                                </SelectItem>
                            </SelectContent>
                        </Select>
                        <p className="text-xs text-muted-foreground">
                            {penaltyMode === 'EITHER_CHOICE'
                                ? 'Offender must choose between social score deduction or credit fine.'
                                : penaltyMode === 'BOTH_MANDATORY'
                                    ? 'Both social score and credit penalties are applied immediately.'
                                    : 'Leave empty for social-score-only deduction (legacy mode).'}
                        </p>
                    </div>

                    <div className="grid gap-2">
                        <Label htmlFor="violation-expires">Expires on (optional, for minor violations)</Label>
                        <Input
                            id="violation-expires"
                            type="datetime-local"
                            value={expiresAt}
                            onChange={(e) => setExpiresAt(e.target.value)}
                        />
                        <p className="text-xs text-muted-foreground">
                            Points will be automatically refunded after this date.
                        </p>
                    </div>
                </div>

                <DialogFooter>
                    <Button
                        variant="outline"
                        onClick={() => onOpenChange(false)}
                        disabled={isSubmitting}
                    >
                        Cancel
                    </Button>
                    <Button onClick={handleSubmit} disabled={isSubmitting}>
                        {isSubmitting ? "Creating..." : "Create"}
                    </Button>
                </DialogFooter>
            </DialogContent>
        </Dialog>
    );
}
