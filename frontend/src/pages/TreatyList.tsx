import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '@/contexts/AuthContext';
import { treatiesApi } from '@/api/treaties';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import {
    Dialog,
    DialogContent,
    DialogHeader,
    DialogTitle,
    DialogTrigger,
} from '@/components/ui/dialog';
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from '@/components/ui/select';
import { Treaty, TreatyStatus, TreatyType } from '@/types';
import { Handshake, Plus, Clock, Users } from 'lucide-react';
import { useToast } from '@/hooks/use-toast';

export default function TreatyList() {
    const { user } = useAuth();
    const navigate = useNavigate();
    const queryClient = useQueryClient();
    const { toast } = useToast();
    const [open, setOpen] = useState(false);
    const [title, setTitle] = useState('');
    const [type, setType] = useState<TreatyType>(TreatyType.NON_EXCHANGE);
    const [endsAt, setEndsAt] = useState('');

    const { data: treaties = [], isLoading } = useQuery({
        queryKey: ['treaties'],
        queryFn: () => treatiesApi.list(),
    });

    const createMutation = useMutation({
        mutationFn: () => treatiesApi.create({ title, type, endsAt }),
        onSuccess: (t) => {
            queryClient.invalidateQueries({ queryKey: ['treaties'] });
            toast({ title: 'Treaty created', description: `"${t.title}" is now in NEGOTIATION.` });
            setOpen(false);
            setTitle('');
            setEndsAt('');
            navigate(`/app/treaties/${t.id}`);
        },
        onError: (e: any) => toast({ title: 'Error', description: e.message, variant: 'destructive' }),
    });

    const statusColor = (s: TreatyStatus) => {
        switch (s) {
            case TreatyStatus.NEGOTIATION: return 'bg-blue-500/20 text-blue-300';
            case TreatyStatus.LOCKED: return 'bg-yellow-500/20 text-yellow-300';
            case TreatyStatus.ACTIVE: return 'bg-green-500/20 text-green-300';
            case TreatyStatus.EXPIRED: return 'bg-red-500/20 text-red-300';
        }
    };

    return (
        <div className="container mx-auto p-6 space-y-6">
            <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                    <Handshake className="h-7 w-7 text-primary" />
                    <h1 className="text-2xl font-bold">Treaties</h1>
                </div>
                {user?.isPrimeMinister && (
                    <Dialog open={open} onOpenChange={setOpen}>
                        <DialogTrigger asChild>
                            <Button>
                                <Plus className="h-4 w-4 mr-2" /> New Treaty
                            </Button>
                        </DialogTrigger>
                        <DialogContent>
                            <DialogHeader>
                                <DialogTitle>Create Treaty</DialogTitle>
                            </DialogHeader>
                            <div className="space-y-4 mt-4">
                                <div>
                                    <label className="text-sm font-medium">Title</label>
                                    <Input value={title} onChange={(e) => setTitle(e.target.value)} placeholder="Treaty title" />
                                </div>
                                <div>
                                    <label className="text-sm font-medium">Type</label>
                                    <Select value={type} onValueChange={(v) => setType(v as TreatyType)}>
                                        <SelectTrigger>
                                            <SelectValue />
                                        </SelectTrigger>
                                        <SelectContent>
                                            <SelectItem value={TreatyType.NON_EXCHANGE}>Non-Exchange</SelectItem>
                                            <SelectItem value={TreatyType.EXCHANGE}>Exchange</SelectItem>
                                        </SelectContent>
                                    </Select>
                                </div>
                                <div>
                                    <label className="text-sm font-medium">Ends At</label>
                                    <Input type="datetime-local" value={endsAt} onChange={(e) => setEndsAt(e.target.value)} />
                                </div>
                                <Button
                                    className="w-full"
                                    onClick={() => createMutation.mutate()}
                                    disabled={!title || !endsAt || createMutation.isPending}
                                >
                                    {createMutation.isPending ? 'Creating...' : 'Create Treaty'}
                                </Button>
                            </div>
                        </DialogContent>
                    </Dialog>
                )}
            </div>

            {isLoading ? (
                <p className="text-muted-foreground">Loading treaties...</p>
            ) : treaties.length === 0 ? (
                <Card className="glass-card">
                    <CardContent className="py-12 text-center">
                        <Handshake className="h-12 w-12 mx-auto text-muted-foreground mb-4" />
                        <p className="text-muted-foreground">No treaties yet. You'll see treaties you're part of here.</p>
                    </CardContent>
                </Card>
            ) : (
                <div className="grid gap-4">
                    {treaties.map((t: Treaty) => (
                        <Card
                            key={t.id}
                            className="glass-card cursor-pointer hover:border-primary/50 transition-colors"
                            onClick={() => navigate(`/app/treaties/${t.id}`)}
                        >
                            <CardHeader className="pb-3">
                                <div className="flex items-center justify-between">
                                    <CardTitle className="text-lg">{t.title}</CardTitle>
                                    <span className={`px-2 py-1 rounded-full text-xs font-medium ${statusColor(t.status)}`}>
                                        {t.status.replace('_', ' ')}
                                    </span>
                                </div>
                            </CardHeader>
                            <CardContent>
                                <div className="flex items-center gap-6 text-sm text-muted-foreground">
                                    <span className="flex items-center gap-1">
                                        <Users className="h-3.5 w-3.5" />
                                        {t.participants.filter((p) => p.status !== 'REJECTED' && p.status !== 'LEFT').length} participants
                                    </span>
                                    <span className="flex items-center gap-1">
                                        <Clock className="h-3.5 w-3.5" />
                                        Ends {new Date(t.endsAt).toLocaleDateString()}
                                    </span>
                                    <span>Type: {t.type === TreatyType.EXCHANGE ? 'Exchange' : 'Non-Exchange'}</span>
                                    <span>By {t.createdBy.username}</span>
                                </div>
                            </CardContent>
                        </Card>
                    ))}
                </div>
            )}
        </div>
    );
}
